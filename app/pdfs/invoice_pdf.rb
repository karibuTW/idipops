class InvoicePdf
	include Prawn::View
	include ActionView::Helpers::NumberHelper

	def initialize transactions
		Prawn::Font::AFM.hide_m17n_warning = true
		# grid.show_all
		@transactions = transactions.select { |transaction| !transaction.invoice_uid.present? }
		if !@transactions.empty?
			define_grid(:columns => 5, :rows => 12, :gutter => 10)
			header
			transactions_table
			footer
		end
	end

	def document
    @my_prawn_doc ||= Prawn::Document.new(page_size: 'A4')
  end

	def header
		first_transaction = @transactions[0]
		grid([0, 0], [1, 2]).bounding_box do
			image "#{Rails.root}/app/assets/images/invoice/invoice-logo.jpg", fit: [250, 50], position: :center, vposition: :center
			text I18n.t("invoices.header.tagline"), valign: :bottom, align: :center, style: :italic
		end

		fill_color "f5f5f5"
		stroke_color "272829"
		grid([0, 3], [1, 4]).bounding_box do
			fill_rectangle [0, bounds.top], bounds.right, bounds.top
			stroke_bounds
		end
		now = Time.now.localtime
		invoice_num = "#{now.strftime('%Y%m%d')}#{first_transaction.id}"
		font_size 9
		fill_color "e65100"
		grid(0, 3).bounding_box do
			indent(5) do
				text "#{I18n.t('invoices.header.date')}\n#{I18n.t('invoices.header.invoice_num')}", valign: :center
			end
		end
		fill_color "272829"
		grid(0, 4).bounding_box do
			text "#{now.strftime(I18n.t("date.formats.default"))}\n#{invoice_num}", valign: :center
		end
		grid([1, 3], [1, 4]).bounding_box do
			indent(5) do
				fill_color "e65100"
				text I18n.t('invoices.header.contact')
				indent(5) do
					fill_color "272829"
					pro = first_transaction.user
					text "#{pro.company_name}\n#{pro.first_name} #{pro.last_name}\n#{pro.addresses.first.formatted_address}"
				end
			end
		end
	end

	def transactions_table
		table_data = [ [I18n.t('invoices.table.transaction_num'), I18n.t('invoices.table.description'), I18n.t('invoices.table.unit_price'), I18n.t('invoices.table.quantity'), I18n.t('invoices.table.amount')]]
		total_ht_amount = 0
		total_ttc_amount = 0
		@transactions.each do |tr|
			total_ttc_amount += tr.amount_cents
			amount = (tr.amount_cents/1.2)
			total_ht_amount += amount
			table_data << [tr.ext_transaction_id, "#{I18n.t('credits.transactions.' + tr.description)} (#{tr.credit_amount})", number_with_precision(amount, precision: 2), 1, number_with_precision(amount, precision: 2)]
		end
		remaining_num_of_rows = 15 - table_data.count
		table_data += Array.new(remaining_num_of_rows, ["", "", "", "", ""])
		table_data += [["", "", "", I18n.t('invoices.table.total_excl'), number_with_precision(total_ht_amount, precision: 2)], ["", "", "", I18n.t('invoices.table.tax_percent'), number_with_precision(total_ttc_amount - total_ht_amount, precision: 2)], ["", "", "", I18n.t('invoices.table.total_incl'), number_with_precision(total_ttc_amount, precision: 2)]]
		grid([3, 0], [9, 4]).bounding_box do
			table(table_data, column_widths: [bounds.right * 0.2, bounds.right * 0.4, bounds.right * 0.15, bounds.right * 0.1, bounds.right * 0.15], cell_style: {border_width: 1, border_color: "d6dbdc"}) do
				row(0).background_color = "e65100"
				row(0).text_color = "ffffff"
				cells.style(:height => 24)
				cells.style do |c|
					c.align = c.row == 0 ? :center : c.column > 1 ? :right : :left
					if c.row > 14
						c.border_width = 0
						if c.column == 3
							c.text_color = "e65100"
							c.font_style = :italic
						elsif c.column == 4
							c.border_width = 1
							c.text_color = "272829"
							if c.row == 15 || c.row == 17
								c.background_color = "f57c00"
								c.text_color = "ffffff"
								if c.row == 17
									c.font_style = :bold
								end
							end
						end
					end
				end

			end
		end
	end

	def footer
		grid([11, 0], [11, 4]).bounding_box do
			font_size 7
			fill_color "272829"
			text I18n.t('invoices.footer.address'), align: :center
			move_down 5
			text "N°TVA FR 27 811573591", align: :center
			move_down 15
			fill_color "888888"
			text I18n.t('invoices.footer.warning'), align: :center, style: :italic
		end
		
	end

	def store
		if !@transactions.empty?
			first_transaction = @transactions[0]
			invoice_path = "#{Rails.root.join('tmp')}/invoice#{first_transaction.id}.pdf"
			save_as(invoice_path)
			path_for_attachment = Pathname.new(invoice_path)
			@transactions.each do |transaction|
				transaction.invoice = path_for_attachment
				transaction.save
			end
			File.delete(invoice_path) if File.exist?(invoice_path)
		else
			puts "Nothing to write"
		end
	end

end