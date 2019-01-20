#!/usr/bin/ruby
require 'pp'
require 'digest/md5'
require 'json'

def files_to_digests files
  result = Hash.new { |k,v| k[v] = [] }
  files.each do |file|
    begin
      hash = Digest::MD5.hexdigest(File.read(file))
      result[hash] << file
    rescue
    end
  end
  result
end

def merge_digests(first, second)
  dupkeys = first.keys & second.keys
  dupkeys.each do |dupkey|
    newlist = (first[dupkey] + second[dupkey]).uniq
    first[dupkey] = newlist
    second.delete(dupkey)
  end
  first.merge(second)
end

case ARGV[0]
when "report"
  unique = Hash.new { |k,v| k[v] = [] }
  Dir.glob("**/**").each do |myfile|
    file = File.absolute_path(myfile)
    begin
      size = File.size(file).to_s
      unique[size] << file
    rescue
    end
  end
  unique.select {|k,v| v.size > 1 }
    .each do |size,files|
       unique[size] = files_to_digests(files)
    end
  puts unique.to_json
when "merge"
  first = JSON.parse(File.read(ARGV[1]))
  second = JSON.parse(File.read(ARGV[2]))
  dupkeys = first.keys & second.keys
  dupkeys.each do |dupkey|
    if first[dupkey].class == Array
      digests = files_to_digests(first[dupkey])
      first[dupkey] = digests
    end
    if second[dupkey].class == Array
      digests = files_to_digests(second[dupkey])
      second[dupkey] = digests
    end
    merged = merge_digests(first[dupkey],second[dupkey])
    first[dupkey] = merged
    second.delete(dupkey)
  end
  puts first.merge(second).to_json
when "delete"
  file = File.read(ARGV[1])
  JSON.parse(file)
    .select {|size,files| files.class == Hash }
    .each do |size,digests|
      digests.each do |digest, files|
        if files.size > 1
		files[1..-1].each {|e| puts e}
        end
      end
  end
when "read"
  file = File.read(ARGV[1])
  JSON.parse(file)
    .select {|size,files| files.class == Hash }
    .each do |size,digests|
      digests.each do |digest, files|
        if files.size > 1
          puts '----'
          files.each {|e| puts e}
        end
      end
  end
else
  puts "report merge read delete"
end
