class AddFidToFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end
  
  def self.up
    self.add_fid('features', Feature, false)
    self.add_fid('shapes', Shape, true)
  end
  
  def self.down
    self.revert_fid('features', Feature)
    self.revert_fid('shapes', Shape)
  end
  
  def self.add_fid(table, model, rename)
    change_table table do |t|
      t.rename :fid, :pid if rename
      t.column :fid, :integer
    end    
    model.reset_column_information
    no_nil = true
    model.all.each do |r|
      pid = r.pid
      if pid.nil?
        no_nil = false
      else
        r.fid = pid[1...pid.size].to_i
        r.save
      end
    end
    change_table table do |t|
      if no_nil
        t.change :fid, :integer, :null => false
        t.index :fid, :name => "#{table}_fid", :unique => true
      else
        t.index :fid, :name => "#{table}_fid"
      end
      t.remove_index :name => "#{table}_pid" if !rename
      t.remove :pid
    end
  end
  
  def self.revert_fid(table, model)
    add_column table, :pid, :string
    model.reset_column_information
    no_nil = true
    model.all.each do |r|
      fid = r.fid
      if fid.nil?
        no_nil = false
      else
        r.pid = "f#{fid.to_s}"
        r.save
      end
    end
    change_table table do |t|
      if no_nil
        t.change :pid, :integer, :null => false
        t.index :pid, :name => "#{table}_pid", :unique => true
      else
        t.index :pid, :name => "#{table}_pid"
      end
      t.remove_index :name => "#{table}_fid"
      t.remove :fid
    end
  end
end