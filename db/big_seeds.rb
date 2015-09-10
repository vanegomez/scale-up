require 'populator'

class BigSeeds
  def run
    create_known_users
    3.times.create_borrowers
    20.times.create_lenders # { create_lenders }
    create_loan_requests_for_each_borrower(17)
    create_categories
    create_orders
  end

  def lenders
    User.where(role: 0)
  end

  def borrowers
    User.where(role: 1)
  end

  def orders
    Order.all
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
    put_requests_in_categories
  end

  def get_categories
    @categories ||= Category.all
  end

  def put_requests_in_categories
    LoanRequest.each do |request|
      get_categories.shuffle.first.loan_requests << request
      puts "linked request and category"
    end
  end

  def create_loan_requests_for_each_borrower(quantity)
    quantity.times do
      borrowers.each do |borrower|
        title = Faker::Commerce.product_name
        description = Faker::Company.catch_phrase
        status = [0, 1].sample
        request_by =
          Faker::Time.between(7.days.ago, 3.days.ago)
        repayment_begin_date =
          Faker::Time.between(3.days.ago, Time.now)
        amount = "200"
        contributed = "0"
        request = borrower.loan_requests.create(title: title,
          description: description,
          amount: amount,
          status: status,
          requested_by_date: request_by,
          contributed: contributed,
          repayment_rate: "weekly",
          repayment_begin_date: repayment_begin_date)
        puts "created loan request #{request.title} for #{borrower.name}"
        puts "There are now #{LoanRequest.count} requests"
      end
    end
  end

  def get_lenders
    @lenders ||= User.where(role: 0).pluck(:id)
  end

  def create_orders
    loan_requests = LoanRequest.limit(50_000)
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    loan_requests.each do |request|
      donate = possible_donations.sample
      lender = get_lenders.sample
      order = Order.create(cart_items:
          { "#{request.id}" => donate },
        user_id: lender.id)
      order.update_contributed(lender)
      puts "Created Order for Request #{request.title} by Lender #{lender.name}"
    end
  end
end


