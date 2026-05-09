class CreateStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :streams do |t|
      t.string :title, limit: 300, null: false
      t.string :stream_url, limit: 200, null: false
      t.integer :platform, null: false, default: 0 # enum: { twitch: 0, you_tube: 1, kick_stream: 2, platform: 3 }
      t.integer :status, null: false, default: 0 # enum: { scheduled: 0, live: 1, ended: 2 }
      t.integer :viewer_count_peak, null: false, default: 0
      t.datetime :scheduled_start, null: false
      t.datetime :actual_start, null: true
      t.datetime :ended_at, null: true
      t.string :vod_url, limit: 200, null: true
      t.references :tournament, null: true, foreign_key: { to_table: :tournaments }
      t.references :streamer, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
