require 'spec_helper'

require 'ammeter/init'
require 'generators/diffit/triggers/triggers_generator'

describe Diffit::TriggersGenerator, type: :generator do

  destination File.expand_path("../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  it "creates triggers migrations" do
    gen = generator %w(posts)
    expect(gen).to receive :create_triggers_migration
    gen.invoke_all
  end

  describe 'migrations' do

    describe 'with ModelName' do

      before do
        run_generator %w(Post)
      end

      subject { migration_file("db/migrate/create_#{Diffit.function_name}_triggers_on_posts.rb") }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackedChangesFunctionTriggersOnPosts < ActiveRecord::Migration} }
      it { is_expected.to contain %r{CREATE TRIGGER #{Diffit.function_name}_on_posts_insert_trigger} }
      it { is_expected.to contain %r{CREATE TRIGGER #{Diffit.function_name}_on_posts_update_trigger} }
    end

    describe 'with table_name' do

      before do
        run_generator %w(authors)
      end

      subject { migration_file("db/migrate/create_#{Diffit.function_name}_triggers_on_authors.rb") }
      it { is_expected.to exist }
      it { is_expected.to contain %r{class CreateTrackedChangesFunctionTriggersOnAuthors < ActiveRecord::Migration} }
      it { is_expected.to contain %r{CREATE TRIGGER #{Diffit.function_name}_on_authors_insert_trigger} }
      it { is_expected.to contain %r{CREATE TRIGGER #{Diffit.function_name}_on_authors_update_trigger} }
    end

  end
end
