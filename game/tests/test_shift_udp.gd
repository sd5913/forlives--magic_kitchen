extends SceneTree
const Receiver = preload("res://scenes/shift/gesture_receiver.gd")
var received: Array[int] = []
var failures := 0
var receiver
var sender := PacketPeerUDP.new()


func _initialize() -> void:
	_run.call_deferred()


func send_sample(number: int, count: int) -> void:
	for i in range(count):
		sender.put_packet(JSON.stringify({"type": "sample", "number": number}).to_utf8_buffer())
		await create_timer(0.01).timeout
		receiver._process(0.1)


func _run() -> void:
	receiver = Receiver.new()
	root.add_child(receiver)
	receiver.set_process(false)
	assert(receiver.listening, "loopback receiver binds")
	receiver.gesture_triggered.connect(func(number): received.append(number))
	sender.set_dest_address("127.0.0.1", 4243)
	await send_sample(2, 6)
	assert(received == [2], "UDP stable sample emits once")
	await send_sample(2, 10)
	assert(received == [2], "UDP held pose not repeated")
	receiver.invalidate()
	await send_sample(4, 6)
	assert(received == [2], "context invalidation requires neutral release")
	await send_sample(-1, 3)
	await send_sample(4, 6)
	assert(received == [2, 4], "release then new stable sample")
	sender.put_packet('{"type":"sample","number":2.5}'.to_utf8_buffer())
	sender.put_packet('{"type":"sample","number":999}'.to_utf8_buffer())
	sender.put_packet('{"type":"sample","number":"2"}'.to_utf8_buffer())
	sender.put_packet('[]'.to_utf8_buffer())
	await create_timer(0.01).timeout
	receiver._process(0.1)
	assert(received == [2, 4], "invalid UDP payloads do not fire")
	receiver.enabled = false
	await send_sample(-1, 3)
	await send_sample(1, 6)
	assert(received == [2, 4], "paused adapter suppresses actions")
	receiver.enabled = true
	await send_sample(1, 6)
	assert(received == [2, 4], "resume cannot consume held pre-pause pose")
	await send_sample(-1, 3)
	await send_sample(0, 6)
	assert(received == [2, 4, 0], "fist triggers after release")
	receiver._process(1.0)
	assert(receiver.latest_number == -1, "stale camera signal released")
	receiver.queue_free()
	sender.close()
	await process_frame
	print("Shift UDP: 9 transport and lifecycle checks passed")
	quit()
