#!/usr/bin/env ruby

#
#This simple file is used to convert leptprotos.h (and possibly other header
#files) into a list of function signatures that ruby ffi can understand.
#

require 'ffi'

class Signature < Struct.new(:name, :return_type, :arguments)
  def to_s
    "[:#{name}, [#{arguments.map{|a|a.inspect}.join(', ')}], #{return_type.inspect}]"
  end
end

class L_RB_TYPE < FFI::Union
  layout :itype, :int64,
         :utype, :uint64,
         :ftype, :double,
         :ptype, :pointer
end

TYPE_MAPPING = {
  'l_uint8' => :uint8,
  'l_uint16' => :uint16,
  'l_int32' => :int32,
  'l_uint32' => :uint32,
  'l_uint64' => :uint64,
  'l_float32' => :float,
  'l_float64' => :double,
  'void' => :void,
  'char' => :char,
  'size_t' => :uint64,
  'L_TIMER' => :pointer,
  'RB_TYPE' => L_RB_TYPE,
  'alloc_fn' => :pointer,
  'dealloc_fn' => :pointer
}

def get_type(s)
  if(s =~ /\*/)
    :pointer
  else
    TYPE_MAPPING[s.split(' ').first]
  end
end

signatures = []
header_file = ARGV[0]
File.open(header_file, 'r') do |f|
  f.each do |line|
    if(line =~ /\w\w*\s*(.*);\s*$/)
      if(line =~ /extern/)
        line['extern'] = ''
      end
      if(line =~ /const/)
        line['const'] = ''
      end
      if(line =~ /LEPT_DLL/)
        line['LEPT_DLL'] = ''
      end
      first, mid, last = line.split(/[\(\)]/)
      name = first.split(' ').last
      return_type = get_type(first)
      arguments = []
      mid.strip!
      if(mid.length > 0 && mid != 'void')
        arguments = mid.split(',').map{|s|get_type(s)}
      end
      signatures << Signature.new(name, return_type, arguments)
    end
  end
end

print "    [\n        "
puts signatures.join(",\n        ")
puts "    ]"
