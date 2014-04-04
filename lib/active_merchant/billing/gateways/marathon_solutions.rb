module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class MarathonSolutionsGateway < Gateway
      self.test_url = 'https://connect15.synapsegateway.net/submit.aspx'
      self.live_url = 'https://connect15.synapsegateway.net/submit.aspx'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'http://www.example.net/'
      self.display_name = 'New Gateway'

      def initialize(options={})
        requires!(options, :syn_act, :password)
        super
      end

      def purchase(money, payment, options={})
        #Set type to S
        post = { Syn_Act: self.options[:syn_act], Syn_Pwd: self.options[:password], Tran_Type: 'S'}
        add_invoice(post, money, options)
        add_payment(post, payment)
        #add_address(post, payment, options)
        add_customer_data(post, options)

        commit('s', post)
      end

      # def authorize(money, payment, options={})
      #   post = {}
      #   add_invoice(post, money, options)
      #   add_payment(post, payment)
      #   add_address(post, payment, options)
      #   add_customer_data(post, options)

      #   commit('authonly', post)
      # end

      # def capture(money, authorization, options={})
      #   commit('capture', post)
      # end

      # def refund(money, authorization, options={})
      #   commit('refund', post)
      # end

      # def void(authorization, options={})
      #   commit('void', post)
      # end

      private

      def add_customer_data(post, options)
        post[:Card_Name] = "Test"
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, money, options)
        post[:Tran_Amt] = money
      end

      def add_payment(post, payment)
        post[:Card_Num] = payment.number
        post[:Card_Exp] = "#{payment.month}/#{payment.year}"

      end

      def parse(body)
        repsonse_hash = {}
        body = body.split("&")
        body.each do |params|
          params = params.split("=")
          if params.length == 2
            p params
            repsonse_hash.merge!({params[0] => params[1]})
          end
        end
        p repsonse_hash
        return repsonse_hash
      end

      def commit(action, parameters)
        url = (test? ? test_url : live_url)
        parameters = format_parameters(parameters)
        header = {"Content-Length" => parameters.length.to_s}
        response = parse(ssl_post(url, parameters, header))
        success = get_success(response)
        Response.new(
          success,
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def format_parameters(params)
        total = ""
        params.each_pair do |k,v|
          total += k.to_s + "="
          total += v.to_s + "&"
        end
        total = total[0..-2]
        return total
      end

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def get_success(response)
        if response["Proc_Resp"] == "Error"
          p "Here"
          return false
        else
          p "Here also"
          return true
        end

      end

      def post_data(action, parameters = {})
      end
    end
  end
end
