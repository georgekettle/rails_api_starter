class UserMailer < ApplicationMailer
  default from: 'no-reply@example.com' # TODO: Change this to your actual domain

  def password_reset(user, token)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/auth/reset-password?token=#{token}"
    
    mail(
      to: @user.email,
      subject: 'Reset your password'
    )
  end
end 


render ReactiveContainer.new do
  render Trigger.new(:cart_items, event: :click, reaction: add_to_cart({name: "Shirt", price: 100})) do |cart_items|
    render Button.new { "Add to Cart" }
  end

  div do
    render Value.new(cart_items: [{name: "Dress", count: 2, price: 100}]) do |cart_items|
      p { "#{cart_items.count} item(s) in cart" }
      cart_items.each do |item|
        render CartItem.new(item)
      end
    end
  end
end
