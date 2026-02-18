# db/seeds.rb

# 1. 記録(TaskLog)を先に全て消す（タスクを消せるようにするため）
TaskLog.destroy_all

# 2. タスクを全て消す
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

puts "Success: All data reset and new tasks created!"

UserScore.find_or_create_by!(id: 1) do |s|
  s.score = 0
end