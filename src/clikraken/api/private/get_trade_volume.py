# -* coding: utf8 -*-

"""
clikraken.api.private.get_trade_volume

This module queries the Get Trade Volume method of Kraken's API
and outputs the results in a tabular format.

Licensed under the Apache License, Version 2.0. See the LICENSE file.
"""

from collections import OrderedDict

from clikraken.api.api_utils import query_api
from clikraken.clikraken_utils import _tabulate as tabulate
from clikraken.clikraken_utils import csv
from clikraken.clikraken_utils import format_timestamp


def get_trade_volume(args):
    """Get trade volume"""

    # Parameters to pass to the API
    api_params = {
        'pair': args.pair,
    }

    res = query_api('private', 'TradeVolume', api_params, args)
    # extract list of ledgers from API results

    fees = res['fees']

    fees_list = []
    for fid, item in fees.items():
        asset_dict = OrderedDict()
        asset_dict['currency'] = res['currency']
        asset_dict['volume'] = res['volume']
        asset_dict['id'] = fid
        asset_dict['fee'] = float(item['fee'])
        asset_dict['min_fee'] = float(item['minfee'])
        asset_dict['max_fee'] = float(item['maxfee'])

        if "nexfee" in item:
            asset_dict['next_fee'] = float(item['nextfee'])

        if "nexvolume" in item:
            asset_dict['next_volume'] = float(item['nextvolume'])

        asset_dict['tier_volume'] = float(item['tiervolume'])

        fees_list.append(asset_dict)

    if not fees_list:
        return

    if args.csv:
        print(csv(fees_list, headers="keys"))
    else:
        print(tabulate(fees_list, headers="keys"))
