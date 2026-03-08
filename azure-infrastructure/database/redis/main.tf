resource "azurerm_resource_group" "redis" {
  name     = "${local.name_prefix}-rg-redis"
  location = var.location
  tags     = local.common_tags
}

# ── Azure Cache for Redis ─────────────────────────────────────────────────────
# ⚠️ NO free tier. C0 Basic is the cheapest at ~$16/month.
# C0 Basic: 250 MB cache, no SLA, no replication, single node — dev/test only.
# To save cost: use rg-destroy workflow to tear down when not in use.
# Use cases: session caching, API response caching, distributed rate limiting,
# Pub/Sub between services, leaderboards.

resource "azurerm_redis_cache" "redis" {
  name                = "${local.name_prefix}-redis"
  location            = azurerm_resource_group.redis.location
  resource_group_name = azurerm_resource_group.redis.name
  capacity            = var.redis_capacity
  family              = var.redis_family
  sku_name            = var.redis_sku
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  tags                = local.common_tags
}
