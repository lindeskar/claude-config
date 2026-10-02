---
name: vendor-pricing-lookup
description: How to read authoritative cloud list prices — WebFetch truncates pricing pages into a false "I can't see it"; GCP/Azure yield to curl + tag-strip, AWS renders prices client-side from a JSON pricing API, and GCP network SKUs bill GiB while the hyperscalers bill decimal GB
metadata:
  type: reference
---

Pricing pages are long, so WebFetch's summarizer hits its content limit and replies that
the content was truncated and it cannot answer. That is a tooling failure that reads like
absence — never conclude the page lacks the number.

- **GCP** (`cloud.google.com/*/pricing`, `/vpc/network-pricing`): `curl` the page and strip
  tags; the rate tables are real server-rendered HTML. Regional tables load dynamically, so
  a scrape yields the default region only — say which region the numbers are from.
- **AWS**: prices are *not* in the HTML. The page ships template tokens like
  `{priceOf!datatransfer/datatransfer!DataTransfer!External!Outbound!Next!10!TB}` resolved
  client-side from
  `https://b0.p.awsstatic.com/pricing/2.0/meteredUnitMaps/<svc>/USD/current/<svc>.json`.
  It is gzipped — `curl --compressed`, then index `regions[<region name>]`.
- **Azure**: WebFetch handles `azure.microsoft.com/pricing/details/*` fine.

**Unit trap when comparing across clouds:** AWS and Azure bill data transfer per decimal
GB (10⁹); GCP network SKUs — Cloud NAT processing, Cloud Storage — bill per **GiB** (2³⁰).
Mixing them understates the GCP side by ~7%. 100 TB = 93,132 GiB.

Worked comparison built this way: work wiki `topics/infra/gcp-public-ip-vs-cloud-nat-cost.md`.
