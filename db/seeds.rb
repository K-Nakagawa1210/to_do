tasks = ["薬を飲む", "手と顔を洗う", "着替える", "水筒を入れる", 
         "連絡ノートを見直し、今日の学校の確認", "宿題・ファイルをしまう", "ご飯を食べる", "歯磨きをする"]

tasks.each_with_index do |name, index|
  Task.find_or_create_by!(name: name, sequence: index + 1)
end