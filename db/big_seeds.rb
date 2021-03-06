require 'populator'

class BigSeeds
  def run
    create_known_users
    3.times  { create_borrowers }
    20.times { create_lenders }
    create_categories
    create_loan_requests_for_each_borrower
    create_orders
  end

  def lenders
    @lenders ||= User.where(role: 0)
  end

  def borrowers
    @borrowers ||= User.where(role: 1)
  end

  def orders
    @orders ||= Order.all
  end

  def create_known_users
    User.create(name: "Jorge", email: "jorge@example.com", password: "password")
    User.create(name: "Rachel", email: "rachel@example.com", password: "password")
    User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
  end

  def create_lenders
    User.populate(10_000) do |u|
      u.name = Faker::Name.name
      u.email = Faker::Internet.email
      u.password_digest = "$2a$10$H10N.BXZbZs65SHCetrqyuGrJg3L.kgrp/k3qXFAKR9WVeirVaBVG"
      u.role = 0
    end
  end

  def create_borrowers
    User.populate(10_000) do |u|
      u.name = Faker::Name.name
      u.email = Faker::Internet.email
      u.password_digest = "$2a$10$H10N.BXZbZs65SHCetrqyuGrJg3L.kgrp/k3qXFAKR9WVeirVaBVG"
      u.role = 1
    end
  end

  def create_categories
    ["agriculture", "community", "education", "environment", "health", "animals", "wildlife", "children", "health", "sports", "elderly", "art", "culture", "human rights", "welfare"].each do |cat|
      Category.create(title: cat, description: cat + " stuff")
    end
  end

  def create_loan_requests_for_each_borrower
    LoanRequest.populate(500_000) do |request|
      request.title = Faker::Commerce.product_name
      request.description = Faker::Company.catch_phrase
      request.amount = 200

      request.status = [0, 1].sample
      request.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
      request.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
      request.repayment_rate = [0, 1].sample
      request.contributed = 0
      request.repayed = 0
      request.user_id = borrowers.sample.id
      LoanRequestsCategory.populate(2) do |category|
        category.loan_request_id = request.id
        category.category_id = Category.all.sample.id
      end
    end
  end

  def create_orders
    loan_requests = LoanRequest.limit(50_000)
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    loan_requests.each do |request|
      donate = possible_donations.sample
      lender = lenders.sample
      order = Order.create(cart_items:
          { "#{request.id}" => donate },
        user_id: lender.id)
      order.update_contributed(lender)
      puts "Created Order for Request #{request.title} by Lender #{lender.name}"
    end
  end
end


