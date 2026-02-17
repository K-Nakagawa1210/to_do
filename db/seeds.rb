# db/seeds.rb

# 1. 一度既存のタスクを全て削除してリセット（確実な反映のため）
Task.destroy_all

tasks = [
  { name: "竜馬くん、おはよう", sequence: 0 },
  { name: "薬を飲む", sequence: 1 },
  { name: "手と顔を洗う", sequence: 2 },
  { name: "着替える", sequence: 3 },
  { name: "水筒を入れる", sequence: 4 },
  { name: "宿題のやり直しをする", sequence: 5 },
  { name: "宿題・連絡ファイルを入れる", sequence: 6 },
  { name: "ごはんを食べる", sequence: 7 },
  { name: "歯をみがく", sequence: 8 }
]

tasks.each do |task_data|
  Task.create!(task_data)
end

puts "Tasks have been re-seeded and updated!"