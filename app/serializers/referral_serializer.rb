class ReferralSerializer < BaseSerializer

    attributes :id,
             :email,
             :workflow_state,
             :reward,
             :customer_name,
             :is_pro,
             :send_at
    def customer_name
      object.customer ? object.customer.pretty_name : ""
    end

    def is_pro
      object.customer ? object.customer.user_type == "pro" : false
    end

    def send_at
      object.created_at
    end
end
