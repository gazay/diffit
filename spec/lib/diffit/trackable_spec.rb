require 'spec_helper'

describe Diffit::Trackable do

  before do
    @model = Class.new { include Diffit::Trackable }
  end

  context 'on class-level' do

    it { expect(@model).to respond_to :changes_since }
    it { expect(@model).to respond_to :changes_since_midnight }

  end

  context 'on instance-level' do

    it { expect(@model.new).to respond_to :changes_since }
    it { expect(@model.new).to respond_to :changes_since_midnight }

  end

  describe '#changes_since' do

    it 'returns an instance of a Diffit::Tracker' do
      tracker = Post.changes_since(1.day.ago)
      expect(tracker).to be_an_instance_of(Diffit::Tracker)
    end

    it 'uses proper timestamp' do
      timestamp = 1.day.ago
      tracker = Post.changes_since(timestamp)
      expect(tracker.timestamp).to eq(timestamp)
    end

  end
end
