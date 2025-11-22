module DNS_Tunnel;

export {
    redef enum Notice::Type += { DNS_TUNNELING_DETECTED };
}

# Track query count per source IP
global query_count: table[addr] of count &default=0;

# Thresholds for behavioral detection
const LONG_DOMAIN_THRESHOLD = 50;
const QUERY_THRESHOLD = 100;
const WINDOW = 10secs;

event zeek_init()
    {
    # Note: For production, consider using SumStats framework for better sliding window support
    }

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count)
    {
    local domain = query;
    local src    = c$id$orig_h;

    # Increase DNS query count for this source
    query_count[src] += 1;

    # Heuristic 1: Very long domain names (typical for tunneling payload)
    if ( |domain| > LONG_DOMAIN_THRESHOLD )
        {
        NOTICE([$note=DNS_TUNNELING_DETECTED,
                $msg=fmt("[LONG DOMAIN] %s -> %s", src, domain),
                $conn=c]);
        }

    # Heuristic 2: Suspicious record type (TXT is common in DNS tunneling)
    if ( qtype == 16 )
        {
        NOTICE([$note=DNS_TUNNELING_DETECTED,
                $msg=fmt("[TXT QUERY] %s -> %s", src, domain),
                $conn=c]);
        }

    # Heuristic 3: Abnormally high DNS query rate in time window
    if ( query_count[src] > QUERY_THRESHOLD )
        {
        NOTICE([$note=DNS_TUNNELING_DETECTED,
                $msg=fmt("[HIGH QUERY RATE] %s made %d queries in %d seconds",
                         src, query_count[src], WINDOW),
                $conn=c]);
        }
    }
