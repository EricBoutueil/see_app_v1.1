class HarboursParamsExtractor
  attr_reader :input_params
  attr_reader :clean_params

  def initialize(input_params)
    @input_params = input_params
  end

  def extract
    cleaned_params = clean_params

    OpenStruct.new({
      name: cleaned_params[:name].presence,

      years: cleaned_params[:year].presence || [Movement::max_year],

      flow: cleaned_params[:flow].presence,

      code: compute_codes(cleaned_params),
    })
  end

  private

  def clean_params
    clean = {
      name: input_params[:name]
    }

    clean[:year] = Array.wrap(input_params[:year]).map do |year|
      year.to_i if Movement::all_years.include?(year.to_i)
    end.compact

    input_flow = if input_params[:flow].is_a?(Enumerable)
      input_params[:flow].first
    else
      input_params[:flow]
    end

    clean[:flow] = input_flow.presence if %w[tot imp exp].include?(input_flow)

    clean[:fam] = input_params[:fam] if input_params[:fam]&.length == 1

    clean[:sub_one] = input_params[:sub_one].presence
    clean[:sub_two] = input_params[:sub_two].presence
    clean[:sub_three] = input_params[:sub_three].presence

    clean
  end

  def compute_codes(cleaned_params)
    return "a" unless cleaned_params[:fam].present?
    return cleaned_params[:fam] unless cleaned_params[:sub_one].present?

    return cleaned_params[:sub_one] unless cleaned_params[:sub_two].present?

    if cleaned_params[:sub_three].blank?
      return merge_codes(cleaned_params[:sub_two], cleaned_params[:sub_one], 2)
    end

    merge_codes(cleaned_params[:sub_three], cleaned_params[:sub_two], 3)
  end

  def merge_codes(codes, merge_with, nb_str)
    codes = codes.dup

    merge_with.each do |code|
      codes << code if codes.none? { |pst| pst.to_s[0, nb_str] == code }
    end

    codes
  end
end
