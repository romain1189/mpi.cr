require "../src/crmpi"

BUF_SIZE = 10 * 1024 * 1024

MPI.init do |universe|
  universe.buffer_size = BUF_SIZE
  raise "assertion error" unless universe.buffer_size == BUF_SIZE

  universe.detach_buffer
  universe.set_buffer_size = BUF_SIZE

  world = universe.world
end
