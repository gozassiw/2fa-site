# How to set up 2fahome

You'll need about 20 minutes. Do the steps in order.

## 1. Create the database (Supabase)
1. Go to supabase.com and create a **new project** for this site. Don't reuse your Jojokev project.
2. Open **SQL Editor → New query**.
3. Open `setup.sql`, change `you@example.com` to your own email (in small letters), paste everything in, and press **Run**.

## 2. Create your admin login
1. In Supabase, open **Authentication → Users → Add user → Create new user**.
2. Enter your email (the same one from step 1) and a strong password. Tick **Auto confirm user**.
3. In **Authentication** settings, turn **off** "Allow new users to sign up", so nobody else can make an account.

## 3. Fill in your settings
1. In Supabase, open **Project Settings → API** (or **API Keys**).
2. Copy the **Project URL** and the **anon / publishable** key.
3. Open `config.js` and paste them in. Also set your site name and Telegram username.
4. Never paste the **service_role** or **secret** key anywhere in these files.

## 4. Put it online (Vercel)
1. Create a new GitHub repository and upload all 5 files:
   `index.html`, `admin.html`, `config.js`, `vercel.json`, `setup.sql`
2. In Vercel, click **Add New → Project**, choose the repository, and press **Deploy**.
3. Connect your domain in the project's **Domains** settings.

## 5. Manage your ads
- Go to **yoursite.com/admin** and log in.
- **Add new ad**: title, link, optional banner picture (any wide size, e.g. 970 × 250 — shown in full), spot 1–6, and an end date.
- The ad disappears by itself after its end date, so you never forget to remove an unpaid ad.
- Each ad shows how many clicks it got. Screenshot this to show advertisers their results.
- Maximum of 6 ads at a time. Delete one to add another.
