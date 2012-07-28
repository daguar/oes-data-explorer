class CreateAreas < ActiveRecord::Migration
  def up
    create_table 'areas' do |t|
      t.string :code, :limit => 8
      t.string :name
      t.string :typecode, :limit => 1
      t.string :state_code, :limit => 2
    end
  end

  def down
    drop_table 'areas'
  end
end
