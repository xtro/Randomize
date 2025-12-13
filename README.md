# Randomize — Delightfully Automatic Test Data for Swift

Randomize is your backstage magician for test data. A single macro turns empty models into living, breathing Swift objects with realistic values that actually *look* like something a human would type. It’s made for engineers who hate boilerplate but love precision — a fluent, expressive API that plays nice with SwiftUI, previews, and testing frameworks alike. You write the model; Randomize makes it come alive.

Designed natively for Apple platforms — pure Swift elegance, no runtime hacks, no regrets.


## Highlights

- **Zero-boilerplate generation with `@Randomize`**  
  Declare your type, mark it up, and watch it populate itself. No manual builders, no factory clutter — just clean Swift that reads like you always wanted it to.

- **Fine-grained control with `@Randomizable(in:)` and `@Unrandomizable`**  
  Set ranges, boundaries, and constraints for each property. You’re still the director; the macro’s just your very efficient assistant who never mistypes.

- **Safe ranges for numerics, dates, strings, and CoreGraphics types**  
  Smart defaults ensure generated values feel natural and stay valid. Your previews and test runs look realistic — not like a math problem gone rogue.

- **Pure Swift, macro-based expansion — readable, inspectable, and fast**  
  No black boxes. Everything expands at compile time, so you can inspect the generated code like a pro. Performance stays razor-sharp, just like your build times.

- **Perfect for SwiftUI Previews, tests, fixtures, and demo data**  
  Whether you’re mocking a UI, seeding tests, or faking data for a pitch demo, Randomize keeps it clean, quick, and aesthetic. Less typing, more shipping.


## Quick Look

Below are real-world scenarios that show how Randomize accelerates your day-to-day work.

1) SwiftUI Preview with realistic content density

```swift
@Randomize
struct Article {
    @Randomizable(in: 20..<80) var title: String     // length 20–79
    @Randomizable(in: 140..<400) var summary: String // length 140–399
    var heroImage: UIImage
}

struct ArticleRow: View {
    let article: Article
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(uiImage: article.heroImage)
                .resizable().scaledToFill().frame(height: 180).clipped()
            Text(article.title).font(.headline)
            Text(article.summary).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Randomized Article") {
    ArticleRow(article: .random())
}
```


## Random generation build flag

⚠️ **Important change in the latest version**: the Randomize macro **only generates random data when the `RANDOMIZING` build flag is explicitly enabled**.

This is intentional. The goal is to ensure that random data generation **can never accidentally leak into production builds** and is always a conscious developer choice.

### Xcode target

Add the flag to the appropriate target:

1. Target ➝ **Build Settings**
2. **Other Swift Flags**
3. Add:

```
-D RANDOMIZING
```

It is strongly recommended to enable this **only for Debug configurations**.

### Swift Package Manager (SPM) module

For SPM targets, define the flag using `swiftSettings`:

```swift
.target(
    name: "YourModule",
    dependencies: ["Randomize"],
    swiftSettings: [
        .define("RANDOMIZING")
    ]
)
```

If the flag is not present, the `@Randomize` macro **does not generate random initializers**, keeping behavior deterministic and production-safe.

This approach ensures that Randomize does its magic where it belongs (previews, tests, demo data), and stays completely silent where it does not.

