require 'rails_helper'

RSpec.describe QuotesController, type: :request do
  let(:user) { create(:user) }
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }
  let(:work) { create(:work, composer: composer) }
  let(:movement) { create(:movement, work: work) }
  let(:quote) { create(:quote) }

  before { sign_in user }

  describe "GET /composers/:composer_id/quotes" do
    let!(:quotes_with_details) do
      [
        create(:quote, :with_details_for_work),
        create(:quote, :with_details_for_movement)
      ]
    end

    before do
      # Link quotes to our composer through work details
      quotes_with_details.each do |quote|
        work_for_quote = create(:work, composer: composer)
        create(:quote_detail, quote: quote, detailable: work_for_quote)
      end
    end

    it "returns success" do
      get "/composers/#{composer.id}/quotes"

      expect(response).to have_http_status(:success)
    end

    it "displays quotes ordered by title" do
      get "/composers/#{composer.id}/quotes"

      expect(response.body).to include(quotes_with_details.first.title)
      expect(response.body).to include(quotes_with_details.second.title)
    end
  end

  describe "GET /composers/:composer_id/works/:work_id/quotes/:id" do
    before do
      create(:quote_detail, quote: quote, detailable: work)
    end

    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}"

      expect(response).to have_http_status(:success)
    end

    it "displays the quote" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}"

      expect(response.body).to include(quote.title)
      expect(response.body).to include(quote.author)
    end
  end

  describe "GET /composers/:composer_id/works/:work_id/movements/:movement_id/quotes/:id" do
    before do
      create(:quote_detail, quote: quote, detailable: movement)
    end

    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes/#{quote.id}"

      expect(response).to have_http_status(:success)
    end

    it "displays the quote" do
      get "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes/#{quote.id}"

      expect(response.body).to include(quote.title)
      expect(response.body).to include(quote.author)
    end
  end

  describe "GET /composers/:composer_id/works/:work_id/quotes/new" do
    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/new"

      expect(response).to have_http_status(:success)
    end

    it "displays form for new quote" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/new"

      expect(response.body).to include("form")
      expect(response.body).to include("Title")
      expect(response.body).to include("Author")
    end

    it "displays existing quotes for linking" do
      other_quote = create(:quote)
      linked_quote = create(:quote)
      create(:quote_detail, quote: linked_quote, detailable: work)

      # Create a quote detail for the other quote but for a different work
      other_work = create(:work, composer: composer)
      create(:quote_detail, quote: other_quote, detailable: other_work)

      get "/composers/#{composer.id}/works/#{work.id}/quotes/new"

      expect(response.body).to include(other_quote.title)
      expect(response.body).not_to include(linked_quote.title)
    end
  end

  describe "GET /composers/:composer_id/works/:work_id/movements/:movement_id/quotes/new" do
    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes/new"

      expect(response).to have_http_status(:success)
    end

    it "displays form for new quote in movement context" do
      get "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes/new"

      expect(response.body).to include("form")
      expect(response.body).to include("Title")
      expect(response.body).to include("Author")
    end
  end

  describe "GET /composers/:composer_id/works/:work_id/quotes/:id/edit" do
    before do
      create(:quote_detail, quote: quote, detailable: work)
    end

    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}/edit"

      expect(response).to have_http_status(:success)
    end

    it "displays edit form" do
      get "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}/edit"

      expect(response.body).to include("form")
      expect(response.body).to include(quote.title)
      expect(response.body).to include(quote.author)
    end
  end

  describe "POST /composers/:composer_id/works/:work_id/quotes" do
    let(:valid_attributes) do
      {
        title: "Musical Inspiration",
        author: "Famous Composer",
        notes: "This is a test quote",
        date: "2023-01-01",
        circa: false
      }
    end

    let(:invalid_attributes) do
      {
        title: "",
        author: "",
        notes: "This is a test quote"
      }
    end

    let(:quote_detail_attributes) do
      {
        category: "inspiration",
        location: "Page 42",
        excerpt_text: "Sample excerpt",
        notes: "Detail notes"
      }
    end

    context "with valid parameters" do
      it "creates a new quote" do
        expect {
          post "/composers/#{composer.id}/works/#{work.id}/quotes",
               params: { quote: valid_attributes, quote_detail: quote_detail_attributes }
        }.to change(Quote, :count).by(1)

        expect(response).to redirect_to([composer, work, Quote.last])
        expect(flash[:notice]).to eq("Quote was successfully created.")
      end

      it "creates associated quote details" do
        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: { quote: valid_attributes, quote_detail: quote_detail_attributes }

        quote = Quote.last
        quote_detail = quote.quote_details.first

        expect(quote_detail.detailable).to eq(work)
        expect(quote_detail.category).to eq("inspiration")
        expect(quote_detail.location).to eq("Page 42")
      end
    end

    context "when linking existing quote" do
      let!(:existing_quote) { create(:quote) }

      it "links existing quote without creating new quote" do
        initial_count = Quote.count

        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: {
               existing_quote_id: existing_quote.id,
               quote_detail: quote_detail_attributes
             }

        expect(Quote.count).to eq(initial_count)
        expect(response).to redirect_to([composer, work, existing_quote])
        expect(flash[:notice]).to eq("Quote was successfully linked.")
      end

      it "creates quote detail association" do
        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: {
               existing_quote_id: existing_quote.id,
               quote_detail: quote_detail_attributes
             }

        quote_detail = existing_quote.quote_details.find_by(detailable: work)
        expect(quote_detail).to be_present
        expect(quote_detail.category).to eq("inspiration")
      end
    end

    context "with invalid parameters" do
      it "does not create a quote" do
        expect {
          post "/composers/#{composer.id}/works/#{work.id}/quotes",
               params: { quote: invalid_attributes, quote_detail: quote_detail_attributes }
        }.not_to change(Quote, :count)
      end

      it "renders new template with unprocessable entity status" do
        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: { quote: invalid_attributes, quote_detail: quote_detail_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays errors on the form" do
        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: { quote: invalid_attributes, quote_detail: quote_detail_attributes }

        expect(response.body).to include("error")
      end
    end
  end

  describe "POST /composers/:composer_id/works/:work_id/movements/:movement_id/quotes" do
    let(:valid_attributes) do
      {
        title: "Movement Quote",
        author: "Movement Author",
        notes: "Movement notes"
      }
    end

    let(:quote_detail_attributes) do
      {
        category: "technical",
        location: "Bar 42-50",
        excerpt_text: "Musical excerpt",
        notes: "Technical analysis"
      }
    end

    context "with valid parameters" do
      it "creates a new quote for movement" do
        expect {
          post "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes",
               params: { quote: valid_attributes, quote_detail: quote_detail_attributes }
        }.to change(Quote, :count).by(1)

        expect(response).to redirect_to([composer, work, movement, Quote.last])
      end

      it "associates quote with movement" do
        post "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes",
             params: { quote: valid_attributes, quote_detail: quote_detail_attributes }

        quote = Quote.last
        quote_detail = quote.quote_details.first

        expect(quote_detail.detailable).to eq(movement)
      end
    end
  end

  describe "PATCH /composers/:composer_id/works/:work_id/quotes/:id" do
    let(:quote_detail) { create(:quote_detail, quote: quote, detailable: work) }

    before { quote_detail }

    let(:new_attributes) do
      {
        title: "Updated Title",
        author: "Updated Author",
        notes: "Updated notes"
      }
    end

    let(:updated_quote_detail_attributes) do
      {
        category: "updated_category",
        location: "Updated location",
        excerpt_text: "Updated excerpt",
        notes: "Updated detail notes"
      }
    end

    context "with valid parameters" do
      it "updates the quote" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}",
              params: { quote: new_attributes, quote_detail: updated_quote_detail_attributes }

        quote.reload
        expect(quote.title).to eq("Updated Title")
        expect(quote.author).to eq("Updated Author")
        expect(quote.notes).to eq("Updated notes")
      end

      it "updates quote details" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}",
              params: { quote: new_attributes, quote_detail: updated_quote_detail_attributes }

        quote_detail.reload
        expect(quote_detail.category).to eq("updated_category")
        expect(quote_detail.location).to eq("Updated location")
        expect(quote_detail.excerpt_text).to eq("Updated excerpt")
      end

      it "redirects to the quote" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}",
              params: { quote: new_attributes, quote_detail: updated_quote_detail_attributes }

        expect(response).to redirect_to([composer, work, quote])
        expect(flash[:notice]).to eq("Quote was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          title: "",
          author: "",
          notes: "Updated notes"
        }
      end

      it "does not update the quote" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}",
              params: { quote: invalid_attributes, quote_detail: updated_quote_detail_attributes }

        quote.reload
        expect(quote.title).not_to eq("")
      end

      it "renders edit template with unprocessable entity status" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}",
              params: { quote: invalid_attributes, quote_detail: updated_quote_detail_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with image management" do
      let(:quote_with_images) { create(:quote) }
      let!(:quote_detail_with_images) { create(:quote_detail, quote: quote_with_images, detailable: work) }

      it "handles image removal successfully" do
        patch "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote_with_images.id}",
              params: {
                quote: new_attributes.merge(keep_images: []),
                quote_detail: updated_quote_detail_attributes
              }

        expect(response).to redirect_to([composer, work, quote_with_images])
      end
    end
  end

  describe "DELETE /composers/:composer_id/works/:work_id/quotes/:id" do
    before do
      create(:quote_detail, quote: quote, detailable: work)
    end

    context "when destruction is successful" do
      it "destroys the quote" do
        expect {
          delete "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}"
        }.to change(Quote, :count).by(-1)
      end

      it "redirects to the work" do
        delete "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}"

        expect(response).to redirect_to([composer, work])
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq("Quote was successfully destroyed.")
      end
    end

    context "when destruction fails" do
      before do
        allow_any_instance_of(Quote).to receive(:destroy).and_return(false)
        allow_any_instance_of(Quote).to receive(:errors).and_return(
          double(full_messages: ["Cannot delete quote"])
        )
      end

      it "redirects back to quote with error message" do
        delete "/composers/#{composer.id}/works/#{work.id}/quotes/#{quote.id}"

        expect(response).to redirect_to([composer, work, quote])
        expect(flash[:alert]).to eq("Cannot delete quote")
      end
    end
  end

  describe "DELETE /composers/:composer_id/works/:work_id/movements/:movement_id/quotes/:id" do
    before do
      create(:quote_detail, quote: quote, detailable: movement)
    end

    it "redirects to the movement after deletion" do
      delete "/composers/#{composer.id}/works/#{work.id}/movements/#{movement.id}/quotes/#{quote.id}"

      expect(response).to redirect_to([composer, work, movement])
      expect(response).to have_http_status(:see_other)
    end
  end

  # Test error handling and edge cases
  describe "error handling" do
    context "when composer not found" do
      it "returns 404" do
        get "/composers/999999/quotes"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when work not found" do
      it "returns 404" do
        get "/composers/#{composer.id}/works/999999/quotes/new"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when movement not found" do
      it "returns 404" do
        get "/composers/#{composer.id}/works/#{work.id}/movements/999999/quotes/new"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when quote not found for work" do
      it "returns 404" do
        get "/composers/#{composer.id}/works/#{work.id}/quotes/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when quote exists but not linked to work" do
      let(:unlinked_quote) { create(:quote) }

      it "returns 404" do
        get "/composers/#{composer.id}/works/#{work.id}/quotes/#{unlinked_quote.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test parameter handling
  describe "parameter validation" do
    context "with Rails 8 params.expect" do
      it "handles valid quote parameters" do
        valid_params = {
          title: "Test Title",
          author: "Test Author",
          notes: "Test Notes",
          date: "2023-01-01",
          circa: false
        }

        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: { quote: valid_params }

        expect(response).to redirect_to([composer, work, Quote.last])
      end

      it "handles valid quote detail parameters" do
        quote_params = {
          title: "Test Title",
          author: "Test Author"
        }

        detail_params = {
          category: "test",
          location: "Test Location",
          excerpt_text: "Test Excerpt",
          notes: "Test Notes"
        }

        post "/composers/#{composer.id}/works/#{work.id}/quotes",
             params: { quote: quote_params, quote_detail: detail_params }

        quote_detail = Quote.last.quote_details.first
        expect(quote_detail.category).to eq("test")
        expect(quote_detail.location).to eq("Test Location")
      end
    end
  end
end
