class StaticPagesController < ApplicationController
  def help

		 
  	@level1_qr = create_qr_url("B.e.w.a.r.e. .o.f. .p.e.r.i.o.d.s...", "Beware of periods.", nil, 1)
  	@level2_qr = create_qr_url("VGhpcyBpcyBhIHRlc3QgbWVzc2FnZQ==", "This is a test message", nil, 2)
  	@level3_qr = create_qr_url("Woah a QR code on a phone", "Yay Computer Science!", "Dg4YSGMOTSEnVAYdRDZDBgtOAkVRaG9uZQ==", 3)
  end


  private
  def create_qr_url(encode, solution, parity, level)
  	dict1 = {:encoded =>  encode, :solution => solution, :level =>  level, :test => true}
  	if not parity.nil?
  		dict1[:parity] = parity
  	end
	j1 = ActiveSupport::JSON
	json1 = j1.encode(dict1)
	return "https://chart.googleapis.com/chart?cht=qr&chs=400x400&chl=" + URI.escape(json1)
  end

end
