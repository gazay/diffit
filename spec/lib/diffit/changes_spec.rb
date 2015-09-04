require 'spec_helper'

describe Diffit::Changes do

  before do
    @timestamp = 5.days.ago
    @changes = Diffit::Changes.new(@timestamp)
  end

  describe "#timestamp" do

    subject { @changes.timestamp }
    it { is_expected.to eql @timestamp }

  end # describe #timestamp

  describe "#length" do

    before do
      @changes.append('Author', [{record_id: 42, column_name: 'rating', value: 1, changed_at: 3.days.ago}])
      @changes.append('Author', [{record_id: 43, column_name: 'rating', value: 2, changed_at: 3.days.ago}])
      @changes.append('Author', [{record_id: 44, column_name: 'rating', value: 3, changed_at: 3.days.ago}])
    end

    subject { @changes.length }
    it { is_expected.to eq(3) }

  end

  describe '#to_h' do

    context 'by default' do

      subject { @changes.to_h }

      it { is_expected.to be_an_instance_of ::Hash }
      it { expect(subject[:changes]).to be_empty }
      it { expect(subject[:timestamp]).to eq(@timestamp.to_i) }

    end

    context 'with some data' do

      before do
        @changes.append('Author', [
          {record_id: 42, column_name: 'first_name', value: 'F', changed_at: @timestamp + 2.days},
          {record_id: 42, column_name: 'last_name',  value: 'L', changed_at: @timestamp + 2.days},
          {record_id: 42, column_name: 'rating',     value: 123, changed_at: @timestamp + 3.days}
        ])
      end

      subject { @changes.to_h[:changes] }

      it { is_expected.to be_an_instance_of ::Array }
      it { expect(subject.length).to eq(1) }

      context 'attributes' do

        subject { @changes.to_h[:changes].first }

        it { expect(subject[:model]).to eq('Author') }
        it { expect(subject[:record_id]).to eq(42) }
        it { expect(subject[:changes].length).to eq(3) }
        it { expect(subject[:changes]).to include Hash[:changed_at, @timestamp + 2.days, :column_name, 'first_name', :value, 'F'] }
        it { expect(subject[:changes]).to include Hash[:changed_at, @timestamp + 2.days, :column_name, 'last_name',  :value, 'L'] }
        it { expect(subject[:changes]).to include Hash[:changed_at, @timestamp + 3.days, :column_name, 'rating',     :value, 123] }

      end
    end
  end

  describe '#prepare!' do

    before do
      @changes.append('Author', [{record_id: 42, column_name: 'first_name', value: 'F', changed_at: @timestamp + 2.days}])
      @changes.append('Author', [{record_id: 42, column_name: 'first_name', value: 'F', changed_at: @timestamp + 2.days}])
    end

    before do
      @changes.prepare!
    end

    subject { @changes }
    it { expect(subject.length).to eq(1) }

  end

  describe '#cleanup!' do

    before do
      @changes.append('Author', [{record_id: 42, column_name: 'first_name', value: 'F', changed_at: @timestamp + 2.days}])
      @changes.append('Author', [{record_id: 42, column_name: 'first_name', value: 'F', changed_at: @timestamp + 2.days}])
    end

    before do
      @changes.cleanup!
    end

    subject { @changes }
    it { expect(subject.length).to eq(0) }

  end
end
