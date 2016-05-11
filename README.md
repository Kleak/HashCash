# HashCash

Hashcash is a proof-of-work algorithm, which has been used as a denial-of-service counter measure technique in a number of systems.

A hashcash stamp constitutes a proof-of-work which takes a parameterizable amount of work to compute for the sender. The recipient (and indeed anyone as it is publicly auditable) can verify received hashcash stamps efficiently. Hashcash was invented by Adam Back in 1997


# How to use it

Call HashCash.mint to generate a stamp and use HashCash.check to verify if this stamp is correct
