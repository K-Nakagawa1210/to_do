# db/seeds.rb
TaskLog.destroy_all
Task.destroy_all

# 朝のタスク
morning_tasks = [
  { name: "竜馬くん、おはよう", sequence: 0, category: "morning" },
  { name: "薬を飲む", sequence: 1, category: "morning" },
  { name: "手と顔を洗う", sequence: 2, category: "morning" },
  { name: "着替える", sequence: 3, category: "morning" },
  { name: "水筒を入れる", sequence: 4, category: "morning" },
  { name: "宿題のやり直しをする", sequence: 5, category: "morning" },
  { name: "宿題・連絡ファイルを入れる", sequence: 6, category: "morning" },
  { name: "ごはんを食べる", sequence: 7, category: "morning" },
  { name: "歯をみがく", sequence: 8, category: "morning" }
]

# 夜のタスク
evening_tasks = [
  { name: "竜馬くん、おかえり", sequence: 0, category: "evening" },
  { name: "風呂に入る", sequence: 1, category: "evening" },
  { name: "服を着る", sequence: 2, category: "evening" },
  { name: "連絡ファイルを出す", sequence: 3, category: "evening" },
  { name: "洗濯物を出す", sequence: 4, category: "evening" },
  { name: "ごはんを食べる", sequence: 5, category: "evening" },
  { name: "明日の薬の準備をする", sequence: 6, category: "evening" },
  { name: "次の日の準備をする", sequence: 7, category: "evening" },
  { name: "水筒を洗う", sequence: 8, category: "evening" },
  { name: "宿題のやり直しをする", sequence: 9, category: "evening" },
  { name: "日記を書く", sequence: 10, category: "evening" },
  { name: "歯磨きをする", sequence: 11, category: "evening" }
]

(morning_tasks + evening_tasks).each { |t| Task.create!(t) }