class CreateStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :streams do |t|
      t.string :title, limit: 300, null: false
      t.string :stream_url, limit: 200, null: false
      t.integer :status, null: false, default: 0 # enum: { scheduled: 0, live: 1, ended: 2 }
      t.integer :platform, null: false, default: 0 # enum: { twitch: 0, you_tube: 1, kick_stream: 2, platform: 3 }
      t.integer :language, null: false, default: 0 # enum: { e_n: 0, d_e: 1, f_r: 2, i_t: 3, e_s: 4, j_p: 5, p_t: 6 }
      t.boolean :is_official, null: false, default: false
      t.integer :viewer_count_peak, null: false, default: 0
      t.datetime :scheduled_start, null: false
      t.datetime :actual_start, null: true
      t.datetime :ended_at, null: true
      t.string :vod_url, limit: 200, null: true
      t.references :tournament, null: true, foreign_key: { to_table: :tournaments, on_delete: :nullify }
      t.references :streamer, null: false, foreign_key: { to_table: :players, on_delete: :restrict }

      t.timestamps
    end
  end
end
