# frozen_string_literal: true

RSpec.describe JekyllOgImage::Config do
  subject { described_class.new }

  describe '#margin_bottom' do
    context 'when border_bottom is not set' do
      it 'returns 80' do
        expect(subject.margin_bottom).to eq(80)
      end
    end

    context 'when border_bottom is set' do
      before do
        subject.border_bottom = { "width" => 10 }
      end

      it 'returns 90' do
        expect(subject.margin_bottom).to eq(90)
      end
    end
  end
end
