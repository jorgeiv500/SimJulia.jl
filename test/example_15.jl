using SimJulia

type Widget
	weight::Float64
end

function produce_widgets(process::Process, buffer::Store)
	while true
		put(process, buffer, [Widget(9.0), Widget(7.0)])
		hold(process, 10.0)
	end
end

function consume_widgets(process::Process, buffer::Store)
	while true
		get(process, buffer, uint(3))
		widgets = get_elements(process, buffer)
		println("$(now(process)) Get widget weights $(widgets[1].weight), $(widgets[2].weight), $(widgets[3].weight))")
		hold(process, 11.0)
	end
end

widget_buffer = Widget[]
for i = 1:10
	push!(widget_buffer, Widget(5.0))
end

sim = Simulation(uint(16))
buffer = Store{Widget}(sim, "Buffer", 11, widget_buffer, true)
for i = 1:3
	p = Process(sim, "Producer $i")
	activate(p, 0.0, produce_widgets, buffer)
end
for i = 1:3
	c = Process(sim, "Consumer $i")
	activate(c, 0.0, consume_widgets, buffer)
end
run(sim, 50.0)
println("$(buffer_monitor(buffer))")
println("$(get_monitor(buffer))")
println("$(put_monitor(buffer))")