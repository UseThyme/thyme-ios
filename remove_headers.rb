def should_crop(lines)
  (0..6).each do |n|
    return false unless lines[n].start_with? "//"
  end
  return false unless lines[7] = ""
  true
end

all_objc = Dir.glob("**/**/**/**/**.{m,h}")
all_objc.each do |path|
  content = File.read path
  lines = content.lines
  next unless should_crop(lines)

  lines = lines[6..-1]
  new_content = content.lines[8..-1].join
  File.write path, new_content
end
