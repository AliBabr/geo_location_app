# frozen_string_literal: true
Stripe.api_key = ENV["STRIPE_API_KEY"]

class StripePayment
  def initialize(user)
    @user = user
  end

  def donate(amount, token)
    charge = Stripe::Charge.create({ amount: amount.to_i, currency: "usd", customer: token })
    if charge.id.present?
      return charge
    else
      false
    end
  end

  def create_customer(card_token)
    customer = Stripe::Customer.create({
      description: "News Article App new customer",
      email: @user.email,
      card: card_token,
    })
    if customer.id.present?
      @user.update(stripe_cutomer_id: customer.id)
      return true
    else
      return false
    end
  end

  def refund(charge_id)
    response = Stripe::Refund.create({
      charge: charge_id,
    })
    if response.id.present?
      return response
    else
      return false
    end
  end




  def tranfer(price, token)
    # response = payment_intent = Stripe::PaymentIntent.create({
    #   payment_method_types: ["card"],
    #   amount: price,
    #   currency: "usd",
    #   transfer_data: {
    #     destination: token,
    #   },
    # })

    response = Stripe::Transfer.create({
      amount: price,
      currency: 'usd',
      destination: token,
      transfer_group: '{ORDER10}',
    })
    
    if response.present?
      return response
    else
      return nil
    end
  end
end
