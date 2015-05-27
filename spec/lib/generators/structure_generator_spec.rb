require 'spec_helper'

require 'ammeter/init'
require 'generators/diffit/structure/structure_generator'

describe Diffit::StructureGenerator, type: :generator do

  destination File.expand_path("../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  it "creates structure migrations" do
    expect(generator).to receive :create_table_migration
    expect(generator).to receive :create_function_migration
    generator.invoke_all
  end

  describe 'migrations' do

    before do
      run_generator
    end

    describe 'tracking function' do
      subject { migration_file('db/migrate/create_tracking_function.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackingFunction < ActiveRecord::Migration} }
      it { is_expected.to contain %r{CREATE OR REPLACE FUNCTION tracking_function()} }
    end

    describe 'tracked changes' do
      subject { migration_file('db/migrate/create_tracked_changes.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackedChanges < ActiveRecord::Migration} }
      it { is_expected.to contain %r{create_table :tracked_changes} }
    end

  end
end
