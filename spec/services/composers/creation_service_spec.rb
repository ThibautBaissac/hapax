require 'rails_helper'

RSpec.describe Composers::CreationService do
  let(:nationality) { create(:nationality) }
  let(:valid_params) do
    {
      first_name: "Ludwig van",
      last_name: "Beethoven",
      nationality_id: nationality.id,
      birth_date: Date.new(1770, 12, 17),
      death_date: Date.new(1827, 3, 26),
      short_bio: "German composer",
      bio: "A German composer and pianist."
    }
  end

  let(:invalid_params) do
    {
      first_name: "",
      last_name: "",
      nationality_id: nil
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a new composer successfully' do
        service = described_class.new(valid_params)

        expect { service.call }.to change(Composer, :count).by(1)
        expect(service.success?).to be true
        expect(service.composer).to be_persisted
        expect(service.composer.first_name).to eq("Ludwig van")
        expect(service.composer.last_name).to eq("Beethoven")
      end
    end

    context 'with invalid parameters' do
      it 'does not create a composer' do
        service = described_class.new(invalid_params)

        expect { service.call }.not_to change(Composer, :count)
        expect(service.success?).to be false
        expect(service.failure?).to be true
        expect(service.composer).not_to be_persisted
      end
    end
  end
end
