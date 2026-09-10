import { createParentHandler } from '../_shared/parent.mjs';
Deno.serve(createParentHandler({env: Deno.env.toObject()}));
