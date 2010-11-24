require File.dirname(__FILE__) + '/../../test_helper'

class MigsTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    @gateway = MigsGateway.new(fixtures(:migs))

    @credit_card    = credit_card('4005550000000001', :month => 5, :year => 2013, :type => :visa)
    @master_card_1  = credit_card('5123456789012346', :month => 5, :year => 2013, :type => :master)
    @master_card_2  = credit_card('5313581000123430', :month => 5, :year => 2013, :type => :master)
    @visa_card_1    = credit_card('4005550000000001', :month => 5, :year => 2013, :type => :visa)
    @vis_card_2     = credit_card('4557012345678902', :month => 5, :year => 2013, :type => :visa)
    @amex_card_1    = credit_card('345678901234564',  :month => 5, :year => 2013, :type => :american_express)
    @diners_card_1  = credit_card('30123456789019',   :month => 5, :year => 2013, :type => :diners_club)
    
    @credit_card_fail = credit_card('1234567812345678',
      :month => Time.now.month,
      :year => Time.now.year
    )
    
    @options = {
      :booking_number => '222222D',
      :unique_id => 'efad6659cea26be50fe36cbdec91f042',
    }

    @options = {
      :order_id => 'TEST/9',
      :description => 'Online Purchase'
    }
    
    @amount = Money.new(100)
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
  
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of Response, response
    assert_success response
    assert !response.authorization.blank?
  end
  
  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
  
    assert response = @gateway.purchase(@amount, @credit_card_fail, @options)
    assert_instance_of Response, response
    assert_failure response
  end
         
  def test_amount_style
    assert_equal '1034', @gateway.send(:amount, 1034)
    assert_equal '1034', @gateway.send(:amount, Money.new(1034))
                                                      
    assert_raise(ArgumentError) do
      @gateway.send(:amount, '10.34')
    end
  end
  
  def test_ensure_does_not_respond_to_authorize
    assert !@gateway.respond_to?(:authorize)
  end
  
  def test_ensure_does_not_respond_to_capture
    assert !@gateway.respond_to?(:capture)
  end
  
  private
  def successful_purchase_response
    "vpc_AVSResultCode=Unsupported&vpc_AcqAVSRespCode=Unsupported&vpc_AcqCSCRespCode=Unsupported&vpc_AcqResponseCode=00&vpc_Amount=1400&vpc_AuthorizeId=029968&vpc_BatchNo=20080206&vpc_CSCResultCode=Unsupported&vpc_Card=MC&vpc_Command=pay&vpc_Locale=en_AU&vpc_MerchTxnRef=91bca776862f19b7757f58fc7dfdf99c&vpc_Merchant=TEST512345USD&vpc_Message=Approved&vpc_OrderInfo=222223&vpc_ReceiptNo=080206029968&vpc_TransactionNo=1572808&vpc_TxnResponseCode=0&vpc_Version=1"
  end
  
  def failed_purchase_response
    "vpc_Amount=1400&vpc_BatchNo=0&vpc_Command=pay&vpc_Locale=en_AU&vpc_MerchTxnRef=ae4dfece4b1791f47407c8fc9364d885&vpc_Merchant=TEST512345USD&vpc_Message=I5154-02061204%3A+Invalid+Card+Number+%3A+CardNum&vpc_OrderInfo=222223&vpc_TransactionNo=0&vpc_TxnResponseCode=7&vpc_Version=1"
  end
end


