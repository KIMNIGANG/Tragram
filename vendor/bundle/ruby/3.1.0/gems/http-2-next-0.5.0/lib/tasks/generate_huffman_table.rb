# frozen_string_literal: true

desc "Generate Huffman precompiled table in huffman_statemachine.rb"
task :generate_table do
  HuffmanTable::Node.generate_state_table
end

require_relative "../http/2/next/header/huffman"

# @private
module HuffmanTable
  BITS_AT_ONCE = HTTP2Next::Header::Huffman::BITS_AT_ONCE
  EOS          = 256

  class Node
    attr_accessor :next, :emit, :final, :depth, :transitions, :id

    @@id = 0 # rubocop:disable Style/ClassVars
    def initialize(depth)
      @next = [nil, nil]
      @id = @@id
      @@id += 1 # rubocop:disable Style/ClassVars
      @final = false
      @depth = depth
    end

    def add(code, len, chr)
      self.final = true if chr == EOS && @depth <= 7
      if len.zero?
        @emit = chr
      else
        bit = (code & (1 << (len - 1))).zero? ? 0 : 1
        node = @next[bit] ||= Node.new(@depth + 1)
        node.add(code, len - 1, chr)
      end
    end

    class Transition
      attr_accessor :emit, :node

      def initialize(emit, node)
        @emit = emit
        @node = node
      end
    end

    def self.generate_tree
      @root = new(0)
      HTTP2Next::Header::Huffman::CODES.each_with_index do |c, chr|
        code, len = c
        @root.add(code, len, chr)
      end
      puts "#{@@id} nodes"
      @root
    end

    def self.generate_machine
      generate_tree
      togo = Set[@root]
      @states = Set[@root]

      until togo.empty?
        node = togo.first
        togo.delete(node)

        next if node.transitions

        node.transitions = Array[1 << BITS_AT_ONCE]

        (1 << BITS_AT_ONCE).times do |input|
          n = node
          emit = ""
          (BITS_AT_ONCE - 1).downto(0) do |i|
            bit = (input & (1 << i)).zero? ? 0 : 1
            n = n.next[bit]
            next unless n.emit

            if n.emit == EOS
              emit = EOS # cause error on decoding
            else
              emit << n.emit.chr(Encoding::BINARY) unless emit == EOS
            end
            n = @root
          end
          node.transitions[input] = Transition.new(emit, n)
          togo << n
          @states << n
        end
      end
      puts "#{@states.size} states"
      @root
    end

    def self.generate_state_table
      generate_machine
      state_id = {}
      id_state = {}
      state_id[@root] = 0
      id_state[0] = @root
      max_final = 0
      id = 1
      (@states - [@root]).sort_by { |s| s.final ? 0 : 1 }.each do |s|
        state_id[s] = id
        id_state[id] = s
        max_final = id if s.final
        id += 1
      end

      File.open(File.expand_path("../http/2/huffman_statemachine.rb", File.dirname(__FILE__)), "w") do |f|
        f.print <<HEADER
# Machine generated Huffman decoder state machine.
# DO NOT EDIT THIS FILE.

# The following task generates this file.
#   rake generate_huffman_table

module HTTP2Next
  module Header
    class Huffman
      # :nodoc:
      MAX_FINAL_STATE = #{max_final}
      MACHINE = [
HEADER
        id.times do |i|
          n = id_state[i]
          f.print "        ["
          string = (1 << BITS_AT_ONCE).times.map do |t|
            transition = n.transitions.fetch(t)
            emit = transition.emit
            unless emit == EOS
              bytes = emit.bytes
              raise ArgumentError if bytes.size > 1

              emit = bytes.first
            end
            "[#{emit.inspect}, #{state_id.fetch(transition.node)}]"
          end.join(", ")
          f.print(string)
          f.print "],\n"
        end
        f.print <<TAILER
      ].each { |arr| arr.each { |subarr| subarr.each(&:freeze) }.freeze }.freeze
    end
  end
end
TAILER
      end
    end

    class << self
      attr_reader :root
    end

    # Test decoder
    def self.decode(input)
      emit = ""
      n = root
      nibbles = input.unpack("C*").flat_map { |b| [((b & 0xf0) >> 4), b & 0xf] }
      until nibbles.empty?
        nb = nibbles.shift
        t = n.transitions[nb]
        emit << t.emit
        n = t.node
      end
      puts "len = #{emit.size} n.final = #{n.final} nibbles = #{nibbles}" unless n.final && nibbles.all? { |x| x == 0xf }
      emit
    end
  end
end
