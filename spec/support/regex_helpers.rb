module RegexHelpers
  def color_regex
    /\033\[[0-9;]+m/.source
  end

  def inv_id_regex
    /~\d+\|\d+@\d+\.\d+~/.source
  end

  def debug_regex
    /debug: \{}/.source
  end

  def bench_regex
    /\d+\.?\d*s \(\d+\.?\d*s CPU\)/.source
  end

  def enter_tail_match_src
    "#{inv_id_regex} #{debug_regex}"
  end

  def exit_tail_match_src
    "completed #{inv_id_regex}"
  end

  def bench_tail_inv_match_src
    "#{bench_tail_match_src} #{inv_id_regex}"
  end

  def bench_tail_match_src
    "completed in #{bench_regex}"
  end

  def bench_tail_neg_match_src
    "completed in"
  end

  def cw_src(wrapped)
    "#{color_regex}#{wrapped}#{color_regex}"
  end
end
