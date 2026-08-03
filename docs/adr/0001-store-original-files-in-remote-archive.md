# Store original files in the remote archive

The product's first stage treats the remote archive as a recoverable archive rather than a compressed convenience copy. We therefore store the original media file as the primary archive copy, because allowing compressed-only archives would reduce storage cost but would break the meaning of restore and weaken user trust after local cleanup.
