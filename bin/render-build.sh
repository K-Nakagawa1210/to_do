#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# データベースの作成とマイグレーション
bundle exec rails db:migrate

# ここに Seed を追加！これによってデプロイ時にデータが投入されます
bundle exec rails db:seed