#include <dynfu/dyn_fusion.hpp>

/* We initialise the dynamic fusion with the initals vertices and normals */
DynFusion::DynFusion(std::vector<cv::Vec3f> vertices, std::vector<cv::Vec3f> /* normals */) {
    /* Sample the deformation nodes */
    int steps = 50;
    std::vector<std::shared_ptr<Node>> deformationNodes;
    for (int i = 0; i < vertices.size(); i += steps) {
        auto dq = std::make_shared<DualQuaternion<float>>(0.f, 0.f, 0.f, 0.f, 0.f, 0.f);
        deformationNodes.push_back(std::make_shared<Node>(vertices[i], dq, 0.f));
    }
    /* Initialise the warp field with the inital frames vertices */
    warpfield = std::make_shared<Warpfield>();
    warpfield->init(deformationNodes);

    for (auto node : deformationNodes) {
        node->setNeighbours(warpfield->findNeighbors(KNN, node));
    }
}

void DynamicFusion::init(cuda::Cloud &vertices) {
    cv::Mat cloudHost;
    cloudHost.create(view_device_.rows(), view_device_.cols(), CV_8UC4);
    vertices.download(view_host_.ptr<void>(), view_host_.step);
    std::vector<cv::Vec3f> canonical(cloudHost.rows * cloudHost.cols);

    for (int y = 0; y < cloudHost.cols; ++y) {
        for (int x = 0; x < cloudHost.rows; ++x) {
            auto point = cloudHost.at<Point>(i, j);
            if (!(std::isnan(point.x) || std::isnan(point.y) || std::isnan(point.z)))  {
                canonical[x + cloudHost.col * y] = cv::Vec3f(point.x, point.y, point.z);
            }
        }
    }
}

/* TODO: Add comment */
DynFusion::~DynFusion() = default;

/* TODO: Add comment */
void DynFusion::initCanonicalFrame() {}

/* TODO: Add comment */
void DynFusion::warpCanonicalToLive() {
    // query the solver passing to it the canonicalFrame, liveFrame, and
    // prevwarpField
}
