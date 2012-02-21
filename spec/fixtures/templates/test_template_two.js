var <%= blueprint[:name] %> = (function() {
  function <%= blueprint[:name] %>() {
    <%= "var optional_variable = #{options[:optional_variable]};" if options %>
  }
  return <%= blueprint[:name] %>;
})();
