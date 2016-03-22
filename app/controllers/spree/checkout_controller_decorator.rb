module TaxCloud
  module Spree
    module CheckoutController
      def self.prepended base
        base.rescue_from SpreeTaxCloud::Error do |exception|
          flash[:error] = exception.message
          redirect_to checkout_state_path(:address)
        end

        base.rescue_from TaxCloud::Errors::ApiError do |exception|
          flash[:error] = ::Spree.t("address_verification_failed")
          redirect_to checkout_state_path(:address)
        end
      end
    end
  end
end

Spree::CheckoutController.prepend ::TaxCloud::Spree::CheckoutController
