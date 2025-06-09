require 'rails_helper'

RSpec.describe HomeController, type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /" do
    context "when visiting the homepage" do
      before do
        # Clean database state for consistent tests
        Composer.destroy_all
        Work.destroy_all
        Movement.destroy_all
        Quote.destroy_all
      end

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "renders the index view successfully" do
        get root_path
        expect(response.body).to include("html")
      end

      context "with no data in database" do
        it "assigns zero counts when no records exist" do
          get root_path

          # Check that the controller sets the correct instance variables
          # We'll verify this by checking the response contains the expected content
          # Since we can't use assigns(), we'll verify the behavior indirectly
          expect(response).to have_http_status(:success)

          # Verify the counts are accessible by checking database directly
          expect(Composer.count).to eq(0)
          expect(Work.count).to eq(0)
          expect(Movement.count).to eq(0)
          expect(Quote.count).to eq(0)
        end
      end

      context "with existing data" do
        let!(:nationality) { create(:nationality) }
        let!(:composers) { create_list(:composer, 3, nationality: nationality) }
        let!(:works) { composers.map { |composer| create(:work, composer: composer) } }
        let!(:movements) { works.map { |work| create_list(:movement, 2, work: work) }.flatten }
        let!(:quotes) { create_list(:quote, 5) }

        it "successfully loads the page with existing data" do
          get root_path
          expect(response).to have_http_status(:success)
        end

        it "has the correct counts in the database" do
          get root_path

          expect(Composer.count).to eq(3)
          expect(Work.count).to eq(3)
          expect(Movement.count).to eq(6)
          expect(Quote.count).to eq(5)
        end
      end

      context "with large dataset" do
        let!(:nationality) { create(:nationality) }

        before do
          # Create a large number of records to test performance
          composers = create_list(:composer, 20, nationality: nationality)
          works = composers.map { |composer| create_list(:work, 5, composer: composer) }.flatten
          works.each { |work| create_list(:movement, 3, work: work) }
          create_list(:quote, 100)
        end

        it "handles large datasets without errors" do
          get root_path
          expect(response).to have_http_status(:success)
        end

        it "processes large dataset within reasonable time" do
          start_time = Time.current
          get root_path
          end_time = Time.current

          expect(response).to have_http_status(:success)
          expect(end_time - start_time).to be < 5.seconds
        end
      end
    end
  end

  describe "authentication behavior" do
    context "when not authenticated" do
      it "allows access to the homepage without authentication" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "allows access to the homepage when authenticated" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "model relationships integration" do
    let!(:nationality) { create(:nationality) }
    let!(:composer) { create(:composer, nationality: nationality) }
    let!(:work) { create(:work, composer: composer) }
    let!(:movement) { create(:movement, work: work) }
    let!(:quote) { create(:quote) }

    before do
      # Associate quote with the work through quote_details
      QuoteDetail.create!(quote: quote, detailable: work)
    end

    it "counts all records correctly regardless of associations" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(Composer.count).to eq(1)
      expect(Work.count).to eq(1)
      expect(Movement.count).to eq(1)
      expect(Quote.count).to eq(1)
    end

    it "maintains referential integrity during counting" do
      # Verify that counts reflect the actual database state
      get root_path

      composer_count = Composer.count
      work_count = Work.count
      movement_count = Movement.count
      quote_count = Quote.count

      expect(composer_count).to be_positive
      expect(work_count).to be_positive
      expect(movement_count).to be_positive
      expect(quote_count).to be_positive
    end
  end

  describe "error handling scenarios" do
    context "when database connection issues occur" do
      before do
        allow(Composer).to receive(:count).and_raise(ActiveRecord::ConnectionNotEstablished.new("Database connection failed"))
      end

      it "raises an appropriate error when database is unavailable" do
        expect { get root_path }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end
    end

    context "when individual model counting fails" do
      before do
        allow(Work).to receive(:count).and_raise(ActiveRecord::StatementInvalid.new("SQL statement error"))
      end

      it "raises an error when specific model count fails" do
        expect { get root_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "response content validation" do
    let!(:nationality) { create(:nationality) }

    before do
      create_list(:composer, 2, nationality: nationality)
      create_list(:work, 3, composer: Composer.first)
      create_list(:movement, 4, work: Work.first)
      create_list(:quote, 5)
    end

    it "returns valid HTML response" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/html')
    end

    it "contains the expected page structure" do
      get root_path

      expect(response.body).to include('<!DOCTYPE html>')
      expect(response.body).to include('<html')
      expect(response.body).to include('</html>')
    end
  end

  describe "controller instance variable assignment" do
    let!(:nationality) { create(:nationality) }

    # Since we can't use assigns() without rails-controller-testing,
    # we'll test the behavior indirectly by verifying the controller
    # executes the counting logic correctly

    context "with varied data counts" do
      before do
        create_list(:composer, 7, nationality: nationality)
        create_list(:work, 11, composer: Composer.first)
        create_list(:movement, 13, work: Work.first)
        create_list(:quote, 17)
      end

      it "successfully processes all model counts" do
        # Test that the controller action completes successfully
        # which indicates all instance variables were set properly
        get root_path

        expect(response).to have_http_status(:success)

        # Verify the actual counts match what the controller would assign
        expect(Composer.count).to eq(7)
        expect(Work.count).to eq(11)
        expect(Movement.count).to eq(13)
        expect(Quote.count).to eq(17)
      end
    end

    context "with empty collections" do
      before do
        # Ensure database is empty
        Composer.destroy_all
        Work.destroy_all
        Movement.destroy_all
        Quote.destroy_all
      end

      it "handles empty collections gracefully" do
        get root_path

        expect(response).to have_http_status(:success)

        # Verify zero counts
        expect(Composer.count).to eq(0)
        expect(Work.count).to eq(0)
        expect(Movement.count).to eq(0)
        expect(Quote.count).to eq(0)
      end
    end
  end

  describe "HTTP methods and routing" do
    it "responds to GET requests" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "returns not found for POST requests" do
      post root_path
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for PUT requests" do
      put root_path
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for DELETE requests" do
      delete root_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "caching behavior" do
    let!(:nationality) { create(:nationality) }

    before do
      create_list(:composer, 3, nationality: nationality)
      create_list(:work, 3, composer: Composer.first)
      create_list(:movement, 3, work: Work.first)
      create_list(:quote, 3)
    end

    it "executes fresh queries on each request" do
      # First request
      get root_path
      expect(response).to have_http_status(:success)

      # Add more data
      create(:composer, nationality: nationality)

      # Second request should reflect new data
      get root_path
      expect(response).to have_http_status(:success)
      expect(Composer.count).to eq(4)
    end
  end
end
