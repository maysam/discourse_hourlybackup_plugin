export default {
  add(rule) {
    return Discourse.ajax("/admin/plugins/subscription-rules/add", {
      type: "rule",
      data: {
        token: rule.get("token"),
        product: rule.get("product"),
        group: rule.get("group"),
        month: rule.get("month"),
      }
    });
  },

  delete(rule) {
    return Discourse.ajax("/admin/plugins/subscription-rules/delete", {
      type: "rule",
      data: {
        rule_id: rule.get("id")
      }
    });
  },

  findAll() {
    return Discourse.ajax("/admin/plugins/subscription-rules/index.json").then(function(result) {
      result.rules = result.rules.map(p => Discourse.rule.create(p));
      return result;
    });
  }
};
