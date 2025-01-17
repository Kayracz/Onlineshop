require 'pagy/extras/array'

class ProductsController < ApplicationController
	include CurrentCart

  before_action :authenticate_admin_user!, only: [:new]

	before_action :set_cart, only: [:index, :show, :about, :women, :kids, :men,
																 :new, :search, :perform_search, :filter,
																 :clear_filters, :edit]

	before_action :set_product, only: [:show, :edit, :update, :destroy]

	def new
		@product = Product.new
	end

    def create
    @category_id = params[:category_id]

    @product = Product.new(product_params)
    @product.save!

    # Creates entries in the stock table to handle the new product.
    # (This could be a create callback on the model, too.)
    Size.all.each do |s|
      Stock.create! product_id: @product.id, size_id: s.id, units: 1
    end
    redirect_to products_path
  end

	def edit
	end

	def show
		@product = Product.find(params[:id])
		@photos = Photo.all
	end

	def update
		@product.update(product_params)
		redirect_to products_path
	end

	def index
		if params.key?(:category)
			@category = Category.find_by_name(params[:category])
			@pagy, @products = pagy(Product.where(category: @category))
		else
			@pagy, @products = pagy(Product.search(params[:search]), items:9)
		end
	end

	def women
		if params.key?(:category)
			@category = Category.find_by_name(params[:category])
			@pagy,@women_product_items = pagy(Product.where(category: @category))
		elsif params.key?(:search)
			@pagy,@women_product_items = pagy(Product.women.search(params[:search]), items:8)
		else
			@pagy,@women_product_items = pagy(Product.women.search(params[:search]), items:8)
		end
	end

	def men
		if params.key?(:category)
			@category = Category.find_by_name(params[:category])
			@pagy,@men_product_items = pagy(Product.where(category: @category))
		elsif params.key?(:search)
			@pagy,@men_product_items = pagy(Product.men.search(params[:search]))
		else
			@pagy,@men_product_items = pagy(Product.men)
		end
	end

	def kids
		if params.key?(:category)
			@category = Category.find_by_name(params[:category])
			@pagy,@kids_product_items = pagy(Product.where(category: @category))
		elsif params.key?(:search)
			@pagy,@kids_product_items = pagy(Product.kids.search(params[:search]))
		else
			@pagy,@kids_product_items = pagy(Product.kids)
		end
	end

	def destroy
		@product = Product.find(params[:id])
		@product.destroy
	end

	def search
	end

	def did_you_mean
	end

	def perform_search
		@results = Product.full_text_search(params[:term])

		if @results.any?
			render :search_results
		else
			@term = params[:term]
			@suggestions = suggestions_for(@term)
			render :did_you_mean
		end
	end

def filter
		@color  = params[:color]
		@price  = params[:price]
		@size   = params[:size]
		@subcat = params[:subcategory]

		price_range = parse_price_rage(@price)
		size_name   = size_name(@size)
		products    = Product.filter(@color, price_range, size_name, @subcat)

		case @subcat
		when "women"
			@pagy, @women_product_items = pagy_array(products, items: 9)
			render :women
		when "men"
			@pagy, @men_product_items = pagy_array(products, items: 9)
			render :men
		when "kids"
			@pagy, @kids_product_items = pagy_array(products, items: 9)
			render :kids
		else
			@pagy, @products = pagy_array(products, items: 9)
			render :index
		end
	end

	def clear_filters
		@subcat = params[:subcat]
		case @subcat
		when "women"
			@pagy, @women_product_items = pagy(Product.women, items: 9)
			render :women
		when "men"
			@pagy, @men_product_items = pagy(Product.men, items: 9)
			render :men
		when "kids"
			@pagy, @kids_product_items = pagy(Product.kids, items: 9)
			render :kids
		else
			@pagy, @products = pagy(Product.all, items: 9)
			render :index
		end
	end

	private

	def suggestions_for(term)
		self.class.checker.correct(term).take(5)
	end

	def self.prepare_products_data
		ret = []
		Product.all.each do |p|
			ret << p.title
			ret << p.description
			ret << p.color
		end
		ret.uniq!
	end

	def self.products_data
		@@products_data ||= prepare_products_data
	end

	def self.checker
		@@checker ||= DidYouMean::SpellChecker.new(dictionary: products_data)
	end

	def size_name(size)
		Size.find_by_id(size)&.name
	end

	def parse_price_rage(range)
		JSON.parse(range) if range.present?
	end

	def set_product
		@product = Product.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def product_params
		params.require(:product).permit(:title, :photo, :color,
																		:description, :price, :category_id,
																		:category, :subcategory, :promo, :codigo)
	end
end
