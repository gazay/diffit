require 'spec_helper'

describe Diffit::Tracker do

  before do
    DatabaseCleaner.start

    @posts = []

    @author = Author.create(first_name: 'F', last_name: 'L', rating: 42)
    @time1  = Time.now
    @posts << Post.create(title: 'title1', body: 'body1', tags: ['tag1', 'tag2'], author_id: @author.id)
    @time2  = Time.now
    @posts << Post.create(title: 'title2', body: 'body2', tags: ['tag3', 'tag4'], author_id: @author.id)
    @time3  = Time.now
  end

  after do
    DatabaseCleaner.clean
  end

  describe '#append' do

    context 'when called with ActiveRecord::Relation (hash-like conditions)' do

      let(:thing) { Post.where(author_id: @author.id) }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with ActiveRecord::Relation (conditions with bind_values)' do

      let(:thing) { Post.where('author_id = ?', @author.id) }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with ActiveRecord::Relation (raw SQL conditions)' do

      let(:thing) { Post.where("author_id = #{@author.id}") } # only for testing purposes!

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with model' do

      let(:thing) { Post }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with ActiveRecord::Associations::CollectionProxy' do

      let(:thing) { @author.posts }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with single record' do

      let(:thing) { @posts.first }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(0) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called with array of records' do

      let(:thing) { [@author, @posts.last] }

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(0) }

    end

    context 'when called after update (with callbacks)' do

      let(:thing) { @author.posts }

      before do
        @posts.first.update_attributes(title: 'new title')
      end

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(5) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(1) }

    end

    context 'when called after update (without callbacks)' do

      let(:thing) { @author.posts }

      before do
        Post.update_all("title = 'new title'")
      end

      it { expect(Diffit::Tracker.new(@time1).append(thing).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(thing).length).to eq(5) }
      it { expect(Diffit::Tracker.new(@time3).append(thing).length).to eq(2) }

    end

    context 'chainable' do

      it { expect(Diffit::Tracker.new(@time1).append(@posts.first).append(@posts.last).length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).append(@posts.first).append(@posts.last).length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).append(@posts.first).append(@posts.last).length).to eq(0) }

    end

  end

  describe '#all' do
    context 'when called after update (without callbacks)' do

      it { expect(Diffit::Tracker.new(@time1).all.length).to eq(8) }
      it { expect(Diffit::Tracker.new(@time2).all.length).to eq(4) }
      it { expect(Diffit::Tracker.new(@time3).all.length).to eq(0) }

    end
  end

end
