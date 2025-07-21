#!/usr/bin/env python3
import asyncio
from aiohttp import web, ClientSession
import urllib.parse
import sys

url = "https://identity.vertigisstudio.com/authorize?client_id=pTmBlZldlUaNrhFn&redirect_uri=http%3A%2F%2Flocalhost%3A7780%2Fa5510196-002b-4e2e-ba4e-8fdb91ee5287%2Fonline-activate&response_mode=form_post&activate=no_grant"

async def handle_post(request):
    status = 404

    try:
        data = await request.post()
        id = data.get("id", "")
        idUrl = data.get("idUrl", "")

        if id and idUrl:
            full_url = f"{idUrl}?id={id}"
            async with ClientSession() as session:
                async with session.get(full_url) as resp:
                    result = await resp.json()
                    accountId = result.get("accountId")
                    if accountId and isinstance(accountId, str):
                        print("VertiGIS Account ID:", accountId)
                        asyncio.get_event_loop().call_later(0.1, shutdown)
                        status=200
        
    except:
        pass
        
    return web.Response(status=status, content_type="text/plain")

def shutdown():
    loop = asyncio.get_event_loop()
    for task in asyncio.all_tasks(loop):
        task.cancel()

async def main():
    app = web.Application()
    app.router.add_post('/{tail:.*}', handle_post)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, 'localhost', 7780)
    await site.start()
    print("Listening: http://localhost:7780/")
    print("Please Visit: " + url)    
    sys.stdout.flush()

    try:
        while True:
            await asyncio.sleep(3600)

    except asyncio.CancelledError:
        await runner.cleanup()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
