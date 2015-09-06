require 'spec_helper'

require 'rspec/rails'
require 'ammeter/init'
require 'generators/diffit/init/init_generator'

describe Diffit::InitGenerator, type: :generator do

  destination File.expand_path("../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  it "creates an initializer and migrations" do
    gen = generator %w(whatever)
    expect(gen).to receive :create_initializer
    expect(gen).to receive :create_table_migration
    expect(gen).to receive :create_function_migration
    gen.invoke_all
  end

  describe 'content' do

    before do
      run_generator %w(tracked_changes)
    end

    describe 'initializer' do
      subject { file('config/initializers/diffit.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain %r{config\.table_name = :tracked_changes} }
      it { is_expected.to contain %r{config\.function_name = :tracked_changes_function} }
      it { is_expected.to contain %r{config\.strategy = :join} }
    end

    describe 'tracking function migration' do
      subject { migration_file('db/migrate/create_tracked_changes_function.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackedChangesFunction < ActiveRecord::Migration} }
      it { is_expected.to contain %r{CREATE OR REPLACE FUNCTION tracked_changes_function()} }
    end

    describe 'tracked changes migration' do
      subject { migration_file('db/migrate/create_tracked_changes.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackedChanges < ActiveRecord::Migration} }
      it { is_expected.to contain %r{create_table :tracked_changes} }
    end

  end
end
