class CreateJobs < ActiveRecord::Migration
  def up
    create_table 'jobs' do |t|
      t.string :code, :limit => 8
      t.string :category
      t.string :title
    end
  end

  def down
    drop_table 'jobs'
  end
end
