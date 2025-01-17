class TransfersController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:new, :create, :show]
  before_action :set_transfer, only: [:show, :edit, :destroy]

  def index
    @transfers = Transfer.all
  end

  def new
    if @cart.product_items.empty?
      redirect_to product_url, notice: 'Tu carrito esta vacio'
      return
    end
    @transfer = Transfer.new
  end


  def create
    @transfer = Transfer.new(transfer_params)
    @transfer.add_product_items_from_cart(@cart)
    if @transfer.save
      Cart.destroy(session[:cart_id])
      session[:cart_id] = nil
      redirect_to @transfer, notice: 'Gracias por su pedido!'
    else
      render :new, notice: 'Porfavor chequea tu informacion'
    end
  end


  def show
  end

  def destroy
    @transfer.destroy
    redirect_to root_url, notice: 'Order deleted'
  end

  private
  def set_transfer
   @transfer = Transfer.find(params[:id])
  end

  def transfer_params
    params.require(:transfer).permit(:name, :email, :phone, :address,
                                  :city, :country, :Nit, :Notas, :terminos)
  end

end


